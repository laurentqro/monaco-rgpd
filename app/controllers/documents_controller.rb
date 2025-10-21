class DocumentsController < ApplicationController
  def index
    render inertia: 'Documents/Index', props: {
      documents: []
    }
  end
end
