class GenerateDocumentsJob < ApplicationJob
  queue_as :default

  def perform(response_id)
    response = Response.find(response_id)
    generator = DocumentGenerator.new(response)
    generator.generate_all
  end
end
