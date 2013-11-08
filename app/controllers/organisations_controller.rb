class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.order(:title)
  end

  def show
    @organisation = Organisation.find(params[:id])
  end
end
