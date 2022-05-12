class ElasticArSync::Elastic::Worker::IndexWorker
  include Sidekiq::Worker
  sidekiq_options queue: :elasticsearch, retry: false

  def perform(klass_str, operation, record_id)
    Rails.logger.debug "[elasticsearch IndexWorker] operation: #{operation} #{klass_str} ID: #{record_id}"
    ElasticArSync::Elastic::Services::DocumentIndexer.new.index_document(klass_str.constantize, operation, record_id)
  end
end