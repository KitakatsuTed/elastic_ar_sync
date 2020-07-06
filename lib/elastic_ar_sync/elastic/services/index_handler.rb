class ElasticArSync::Elastic::Services::IndexHandler
  def initialize(klass)
    @klass = klass
  end

  # インデックスを作成 デフォルトは クラス名の小文字_環境名
  def create_index(new_index_name)
    @klass.__elasticsearch__.client.indices.create index: new_index_name, body: { settings: @klass.settings.to_hash, mappings: @klass.mapping.to_hash }
  end

  def delete_index(target_index)
    raise 'can not delete because this index is using now' if target_index == target_alias

    @klass.__elasticsearch__.client.indices.delete index: target_index rescue false
  end

  # DBの内容をESのインデックスに同期する
  # レコード量が多いと時間がかかるのでこれだけは非同期実行
  def import_all_record(target_index ,batch_size = 100)
    @klass.__elasticsearch__.import(index: target_index, batch_size: batch_size)
  end

  # ダウンタイムなしでインデックスを切り替える
  # https://techlife.cookpad.com/entry/2015/09/25/170000
  def switch_alias(alias_name:, new_index_name:)
    raise 'this is already assigned' if new_index_name == target_alias

    actions = [{ add: { index: new_index_name, alias: alias_name } }]
    old_indexes = @klass.get_aliases.keys
    old_indexes.each { |old_index| actions << { remove: { index: old_index, alias: alias_name } } }

    @klass.__elasticsearch__.client.indices.update_aliases(body: { actions: actions })
  end

  private

  def target_alias
    @klass.get_aliases.keys.select { |index| @klass.get_aliases[index]["aliases"].present? }.first
  end
end