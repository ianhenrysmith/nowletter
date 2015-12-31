class MessagesController < ApplicationController
  before_filter :log_params

  def index
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def log_params
    Rails.logger.info params
  end
end
