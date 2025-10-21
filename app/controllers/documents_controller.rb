class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    render inertia: 'Documents/Index', props: {
      documents: []
    }
  end
end
