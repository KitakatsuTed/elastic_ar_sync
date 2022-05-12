class ElasticArSync::Elastic::Worker::IndexWorker
  include Sidekiq::Worker
  sidekiq_options queue: :elasticsearch, retry: false

  def perform(klass, operation, record_id)
    Rails.logger.debug "[elasticsearch IndexWorker] operation: #{operation} #{klass} ID: #{record_id}"
    ElasticArSync::Elastic::Services::DocumentIndexer.new.index_document(klass, operation, record_id)
  end
end