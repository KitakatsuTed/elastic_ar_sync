class ElasticArSync::Elastic::Services::DocumentIndexer
  def index_document(klass, operation, record_id)
    case operation.to_s
    when /index/
      record = Object.const_get(klass).find(record_id)

      Elasticsearch::Model.client.index(
        index: record.__elasticsearch__.index_name,
        type: record.__elasticsearch__.document_type,
        id: record.id,
        body: record.__elasticsearch__.as_indexed_json)
    when /delete/
      Elasticsearch::Model.client.delete(index: Object.const_get(klass).__elasticsearch__.index_name,
                            type: Object.const_get(klass).__elasticsearch__.document_type,
                            id: record_id)
    else
      raise ArgumentError, "Unknown operation '#{operation.to_s}'"
    end
  end
end

