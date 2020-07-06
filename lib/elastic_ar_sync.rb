require "elastic_ar_sync/railtie"

module ElasticArSync
  module Elastic
    module Services
      autoload :DocumentIndexer, 'elastic_ar_sync/elastic/services/document_indexer'
      autoload :IndexHandler, 'elastic_ar_sync/elastic/services/index_handler'
    end
    module Worker
      autoload :IndexImportWorker, 'elastic_ar_sync/elastic/worker/index_import_worker'
      autoload :IndexWorker, 'elastic_ar_sync/elastic/worker/index_worker'
    end
    autoload :Syncable, 'elastic_ar_sync/elastic/syncable'
  end
end
