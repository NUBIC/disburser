class DisburserRequestsController < ApplicationController
  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction
  before_action :load_repository, only: [:new, :create, :edit, :update]
  before_action :load_disburser_request, only: [:edit, :update, :edit_admin_status, :edit_data_status, :edit_specimen_status, :download_file, :data_status, :specimen_status, :admin_status, :edit_committee_review, :committee_review, :cancel]
  before_action :load_specimen_types, only: [:new, :create, :edit, :update]

  def index
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @repositories = Repository.is_public.order('name ASC')
    @disburser_requests = current_user.disburser_requests.by_repository(params[:repository_id]).by_feasibility(params[:feasibility]).by_status(params[:status]).by_data_status(params[:data_status]).by_specimen_status(params[:specimen_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def admin
    authorize DisburserRequest
    params[:page]||= 1
    params[:feasibility]||= 'no'
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @repositories = Repository.all.order('name ASC')
    @disburser_requests = current_user.admin_disbursr_requests.by_repository(params[:repository_id]).by_feasibility(params[:feasibility]).by_status(params[:status]).by_data_status(params[:data_status]).by_specimen_status(params[:specimen_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def data_coordinator
    authorize DisburserRequest
    params[:page]||= 1
    params[:data_status]||= DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_NOT_STARTED
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @repositories = Repository.all.order('name ASC')
    @disburser_requests = current_user.data_coordinator_disbursr_requests.by_repository(params[:repository_id]).by_feasibility(params[:feasibility]).by_status(params[:status]).by_data_status(params[:data_status]).by_specimen_status(params[:specimen_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def specimen_coordinator
    authorize DisburserRequest
    params[:page]||= 1
    params[:data_status]||= DisburserRequest::DISBURSER_REQUEST_DATA_STATUS_DATA_CHECKED
    params[:specimen_status]||= DisburserRequest::DISBURSER_REQUEST_SPECIMEN_STATUS_NOT_STARTED
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @repositories = Repository.all.order('name ASC')
    @disburser_requests = current_user.specimen_coordinator_disbursr_requests.by_repository(params[:repository_id]).by_feasibility(params[:feasibility]).by_status(params[:status]).by_data_status(params[:data_status]).by_specimen_status(params[:specimen_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def committee
    authorize DisburserRequest
    params[:page]||= 1
    params[:status]||= DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
    params[:vote_status]||= DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @repositories = Repository.all.order('name ASC')
    @disburser_requests = current_user.committee_disburser_requests(status: params[:status]).by_repository(params[:repository_id]).by_vote_status(current_user, params[:vote_status]).search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def new
    @disburser_request = @repository.disburser_requests.new(submitter: current_user)
    @disburser_request.disburser_request_details.new
  end

  def edit
    authorize @disburser_request
  end

  def create
    add_file_uload('methods_justifications')
    add_file_uload('custom_request_form')
    add_file_uload('supporting_document')

    @disburser_request = @repository.disburser_requests.build(disburser_request_params)

    remove_file_uload('methods_justifications')
    remove_file_uload('custom_request_form')
    remove_file_uload('supporting_document')

    @disburser_request.submitter = current_user
    @disburser_request.status_user = current_user

    if @disburser_request.save
      flash[:success] = 'You have successfully created a repository request.'
      redirect_to disburser_requests_url
    else
      flash.now[:alert] = 'Failed to create repository request.'
      render action: 'new'
    end
  end

  def update
    authorize @disburser_request
    remove_file_uload('methods_justifications')
    remove_file_uload('custom_request_form')
    remove_file_uload('supporting_document')

    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user

    if @disburser_request.save
      flash[:success] = 'You have successfully updated a repository request.'
      redirect_to disburser_requests_url
    else
      flash.now[:alert] = 'Failed to update repository request.'
      render action: 'edit'
    end
  end

  def download_file
    authorize @disburser_request
    case params[:file_type]
    when 'custom_request_form'
      file = @disburser_request.custom_request_form.path
    when 'methods_justifications'
      file = @disburser_request.methods_justifications.path
    when 'supporting_document'
      file = @disburser_request.supporting_document.path
    end

    return send_file file, disposition: 'attachment', x_sendfile: true unless file.blank?
  end

  def edit_admin_status
    authorize @disburser_request
    load_specimen_types_from_disburser_request
    @disburser_request.status_at = DateTime.now.to_s(:date)
    @disburser_request.data_status_status_at = DateTime.now.to_s(:date)
    @disburser_request.specimen_status_status_at = DateTime.now.to_s(:date)
  end

  def edit_committee_review
    authorize @disburser_request
    @disburser_request_vote = @disburser_request.find_or_initialize_disburser_request_vote(current_user)
  end

  def edit_data_status
    authorize @disburser_request
    @disburser_request.data_status_status_at = DateTime.now.to_s(:date)
  end

  def edit_specimen_status
    authorize @disburser_request
    @disburser_request.specimen_status_status_at = DateTime.now.to_s(:date)
  end

  def data_status
    authorize @disburser_request
    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user
    if @disburser_request.save
      flash[:success] = 'You have successfully updated the status of a repository request.'
      redirect_to data_coordinator_disburser_requests_url
    else
      @disburser_request.data_status_status_at = DateTime.now.to_s(:date)
      flash.now[:alert] = 'Failed to update the status of a repository request.'
      render action: 'edit_data_status'
    end
  end

  def specimen_status
    authorize @disburser_request
    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user
    if @disburser_request.save
      flash[:success] = 'You have successfully updated the status of a repository request.'
      redirect_to specimen_coordinator_disburser_requests_url
    else
      @disburser_request.specimen_status_status_at = DateTime.now.to_s(:date)
      flash.now[:alert] = 'Failed to update the status of a repository request.'
      render action: 'edit_specimen_status'
    end
  end

  def admin_status
    authorize @disburser_request
    load_specimen_types_from_disburser_request
    remove_file_uload('methods_justifications')
    remove_file_uload('custom_request_form')
    remove_file_uload('supporting_document')
    @disburser_request.assign_attributes(disburser_request_params)
    @disburser_request.status_user = current_user

    if @disburser_request.save
      flash[:success] = 'You have successfully updated the status of a repository request.'
      redirect_to admin_disburser_requests_url
    else
      @disburser_request.status_at = DateTime.now.to_s(:date)
      @disburser_request.data_status_status_at = DateTime.now.to_s(:date)
      @disburser_request.specimen_status_status_at = DateTime.now.to_s(:date)
      flash.now[:alert] = 'Failed to update the status of a repository request.'
      render action: 'edit_admin_status'
    end
  end

  def cancel
    authorize @disburser_request
    @disburser_request.status = DisburserRequest::DISBURSER_REQUEST_STATUS_CANCELED
    @disburser_request.status_user = current_user
    if @disburser_request.save
      flash[:success] = 'You have successfully canceled the repository request.'
      redirect_to disburser_requests_url
    else
      flash.now[:alert] = 'Failed to cancel the repository request.'
      redirect_to disburser_requests_url
    end
  end

  private
    def load_specimen_types_from_disburser_request
      @specimen_types = @disburser_request.repository.specimen_types.order('name ASC').map { |specimen_type| [specimen_type.name, specimen_type.id] }
    end

    def load_specimen_types
      @specimen_types = @repository.specimen_types.order('name ASC').map { |specimen_type| [specimen_type.name, specimen_type.id] }
    end

    def disburser_request_params
      params.require(:disburser_request).permit(:status_at, :data_status_status_at, :specimen_status_status_at, :data_status_comments, :specimen_status_comments, :status_comments, :status, :data_status, :specimen_status, :title, :investigator, :irb_number, :feasibility, :cohort_criteria, :data_for_cohort, :methods_justifications, :methods_justifications_cache, :remove_methods_justifications, :custom_request_form, :custom_request_form_cache, :remove_custom_request_form, :supporting_document, :supporting_document_cache, :remove_supporting_document, disburser_request_details_attributes: [:disburser_request_id, :id, :specimen_type_id, :quantity, :volume, :comments, :_destroy], disburser_request_statuses_attributes: [:disburser_request_id, :id, :status_at])
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end

    def load_disburser_request
      @disburser_request = DisburserRequest.find(params[:id])
    end

    def sort_column
      ['title', 'submitted_at', 'investigator', 'irb_number', 'feasibility', 'status', 'data_status', 'specimen_status', 'users.last_name', 'repositories.name'].include?(params[:sort]) ? params[:sort] : 'submitted_at'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    end

    def remove_file_uload(file)
      if params[:disburser_request]["#{file}_cache".to_sym].blank? && params[:disburser_request][file.to_sym].blank?
        @disburser_request[file.to_sym] = nil
      end
    end

    def add_file_uload(file)
      if !params[:disburser_request]["#{file}_cache".to_sym].blank? && params[:disburser_request][file.to_sym].blank?
        params[:disburser_request][file.to_sym] = params[:disburser_request]["#{file}_cache".to_sym]
      end
    end
end