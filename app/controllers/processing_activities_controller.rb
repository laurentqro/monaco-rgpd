class ProcessingActivitiesController < ApplicationController
  def index
    render inertia: 'ProcessingActivities/Index', props: {
      activities: []
    }
  end
end
