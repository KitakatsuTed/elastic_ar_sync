module ElasticArSync
  module Elastic
    module Syncable
      extend ActiveSupport::Concern
      include ElasticArSync::Elastic::Worker
      include ElasticArSync::Elastic::Services

      included do
        include Elasticsearch::Model

        index_name "#{self.to_s.downcase.pluralize}_#{Rails.env}"

        # after_commitでRDBを操作した時にESのインデックスも同期させる
        # アプリのサーバーに負荷をかけ無いように非同期で実行させる
        after_commit on: [:create] do
          document_sync_create(self.class, id)
        end

        after_commit on: [:update] do
          document_sync_update(self.class, id)
        end

        after_commit on: [:destroy] do
          document_sync_delete(self.class, id)
        end

        def document_sync_create(klass, record_id)
          ElasticArSync::Elastic::Worker::IndexWorker.perform_async(klass, :index, record_id)
        end

        def document_sync_update(klass, record_id)
          ElasticArSync::Elastic::Worker::IndexWorker.perform_async(klass, :index, record_id)
        end

        def document_sync_delete(klass, record_id)
          ElasticArSync::Elastic::Worker::IndexWorker.perform_async(klass, :delete, record_id)
        end

        def as_indexed_json(_option = {})
          hash = {}
          self.class.mapping_list_keys.each { |key| hash[key.to_s] = send(key) }
          hash.as_json
        end
      end

      module ClassMethods
        def index_setup
          response = create_index
          switch_alias(new_index_name: response["index"])
          import_all_record(target_index: response["index"])
        end
        # インデックスを作成 デフォルトは クラス名の小文字_環境名
        def create_index
          ElasticArSync::Elastic::Services::IndexHandler.new(self).create_index("#{index_name}_#{Time.zone.now.strftime('%Y%m%d%H%M')}")
        end

        def delete_index(target_index)
          ElasticArSync::Elastic::Services::IndexHandler.new(self).delete_index(target_index)
        end

        # DBの内容をESのインデックスに同期する
        def import_all_record(target_index: ,batch_size: 100)
          ElasticArSync::Elastic::Worker::IndexImportWorker.perform_async(self, target_index, batch_size)
        end

        # ダウンタイムなしでインデックスを切り替える
        # https://techlife.cookpad.com/entry/2015/09/25/170000
        def switch_alias(new_index_name:)
          ElasticArSync::Elastic::Services::IndexHandler.new(self).switch_alias(alias_name: index_name, new_index_name: new_index_name)
        end

        def index_config(dynamic: 'false', override_settings: {}, attr_mappings: default_index_mapping, override_mappings: {})
          attr_mappings.merge!(override_mappings) if override_mappings.present?

          settings default_index_setting.merge!(override_settings) do
            # ES6からStringが使えないのでtextかkeywordにする。
            mappings dynamic: dynamic do
              attr_mappings.each do |key, value|
                next unless value.is_a?(Hash)

                if value[:type].to_s == 'nested'
                  indexes key ,value.reject { |k, _| k.to_sym == :nested_attr } do
                    value[:nested_attr].each { |key, value| indexes key, value }
                  end
                  next
                end

                indexes key, value
              end
            end
          end
        end

        def default_index_setting
          { index: { number_of_shards: 1 } }
        end

        def default_index_mapping
          mapping = {}
          attribute_types.each do |attribute, active_model_type|
            type = active_model_type.type
            type = :text if (active_model_type.type.to_sym == :string) || (type == :integer && defined_enums.symbolize_keys.keys.include?(attribute.to_sym))
            type = :date if active_model_type.type == :datetime
            mapping[attribute.to_sym] = { type: type }
          end
          mapping
        end

        def mapping_list_keys
          mappings.to_hash[:_doc][:properties].keys
        end

        def get_aliases
          begin
            __elasticsearch__.client.indices.get_alias(index: '')
          rescue Elasticsearch::Transport::Transport::Errors::NotFound
            raise Elasticsearch::Transport::Transport::Errors::NotFound, "インデックスがありません alias_name: #{alias_name}"
          end
        end

        def current_index
          get_aliases.select { |_, value| value["aliases"].present? }.keys.first
        end

        def current_mapping
          __elasticsearch__.client.indices.get_mapping[current_index]["mappings"]["_doc"]["properties"]
        end
      end
    end
  end
end
