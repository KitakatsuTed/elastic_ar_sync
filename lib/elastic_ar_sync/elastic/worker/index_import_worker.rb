class ElasticArSync::Elastic::Worker::IndexImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :elasticsearch, retry: false

  def perform(klass_str, target_index, batch_size)
    Rails.logger.debug "[elastic IndexImportWorker] start import #{target_index}"

    begin
      ElasticArSync::Elastic::Services::IndexHandler.new(Object.const_get(klass_str)).import_all_record(target_index, batch_size)
    rescue => e
      Rails.logger.debug "[elastic IndexImportWorker] error occur #{target_index} \n #{e.message}"
    end

    Rails.logger.debug "[elastic IndexImportWorker] finish import #{target_index}"
  end
end