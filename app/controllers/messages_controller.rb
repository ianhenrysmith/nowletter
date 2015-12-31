class MessagesController < ApplicationController
  before_filter :log_params

  def index
  end

  def create
    ParamMessage.create(body: params.to_json.to_s)
  end

  def update
  end

  def destroy
  end

  private

  def log_params
    puts params
  end
end
