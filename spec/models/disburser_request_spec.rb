require 'rails_helper'
require 'active_support'

RSpec.describe DisburserRequest, type: :model do
  it { should belong_to :repository }
  it { should belong_to :submitter }
  it { should have_many :disburser_request_details }
  it { should have_many :disburser_request_statuses }
  it { should have_many :disburser_request_votes }

  it { should validate_presence_of :investigator }
  it { should validate_presence_of :title }
  it { should validate_presence_of :methods_justifications }
  it { should validate_presence_of :cohort_criteria }
  it { should validate_presence_of :data_for_cohort }
  it { should validate_presence_of :status }
  it { should validate_presence_of :fulfillment_status }

  before(:each) do
    @moomin_repository = FactoryGirl.build(:repository, name: 'Moomin Repository')
    @moomin_repository.save!
    @specimen_type_blood = 'Blood'
    @specimen_type_tissue = 'Tissue'
    @moomin_repository.specimen_types.build(name: @specimen_type_blood)
    @moomin_repository.specimen_types.build(name: @specimen_type_tissue)
    @moomintroll_user = FactoryGirl.create(:user, email: 'moomintroll@moomin.com', username: 'moomintroll', first_name: 'Moomintroll', last_name: 'Moomin')
    @little_my_user = FactoryGirl.create(:user, email: 'little_my@moomin.com', username: 'little_my', first_name: 'Little My', last_name: 'Moomin')
    @the_groker_user = FactoryGirl.create(:user, email: 'the_groke@moomin.com', username: 'the_groke', first_name: 'The', last_name: 'Groke')
  end

  it 'should not validate the presence of irb number if feasibility is true', focus: false do
    disburser_request = FactoryGirl.build(:disburser_request, feasibility: true, irb_number: nil)
    disburser_request.valid?
    expect(disburser_request.errors.messages[:irb_number]).to be_empty
  end

  it 'should validate the presence of irb number if feasibility is false', focus: false do
    disburser_request = FactoryGirl.build(:disburser_request, feasibility: false, irb_number: nil)
    disburser_request.valid?
    expect(disburser_request.errors.messages[:irb_number]).to eq(["can't be blank"])
  end

  it "defaults status to 'draft' for a new record that does not provide a status", focus: false do
    disburser_request = DisburserRequest.new
    expect(disburser_request.status).to eq(DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)
  end

  it "leaves status intact for a new record that provides a status", focus: false do
    disburser_request = DisburserRequest.new(status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
  end

  it 'can search accross fields (by title)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure cancer', investigator: 'placehoder', irb_number: 'placehoder', cohort_criteria: 'placehoder', data_for_cohort: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure heart disease',  investigator: 'placehoder', irb_number: 'placehoder', cohort_criteria: 'placehoder', data_for_cohort: 'placehoder')
    expect(DisburserRequest.search_across_fields('Cancer')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by title) case insensitively', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure cancer', investigator: 'placehoder', irb_number: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure heart disease',  investigator: 'placehoder', irb_number: 'placehoder')
    expect(DisburserRequest.search_across_fields('CANCER')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by investigator)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'richard rorty', irb_number: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'daniel dennet', irb_number: 'placehoder')
    expect(DisburserRequest.search_across_fields('rorty')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by investigator) case insensitively', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'richard rorty', irb_number: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'daniel dennet', irb_number: 'placehoder')
    expect(DisburserRequest.search_across_fields('RORTY')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by irb number)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'placehoder', irb_number: 'irb123')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'placehoder', irb_number: 'irb789')
    expect(DisburserRequest.search_across_fields('irb123')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (by irb number) case insensitively', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder', investigator: 'placehoder', irb_number: 'irb123')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'placeholder',  investigator: 'placehoder', irb_number: 'irb789')
    expect(DisburserRequest.search_across_fields('IRB123')).to match_array([disburser_request_1])
  end

  it 'can search accross fields (and sort ascending/descending by a passed in column)', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'a', investigator: 'b')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'b', investigator: 'a')

    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'title', sort_direction: 'asc' })).to eq([disburser_request_1, disburser_request_2])
    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'title', sort_direction: 'desc' })).to eq([disburser_request_2, disburser_request_1])

    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'investigator', sort_direction: 'asc' })).to eq([disburser_request_2, disburser_request_1])
    expect(DisburserRequest.search_across_fields(nil, { sort_column: 'investigator', sort_direction: 'desc' })).to eq([disburser_request_1, disburser_request_2])
  end

  it 'knows if a request is mine', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.mine?(@moomintroll_user)).to be_truthy
  end

  it 'knows if a request is not mine', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.mine?(@little_my_user)).to be_falsy
  end

  it 'knows if a request is a draft', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT)
    expect(disburser_request_1.draft?).to be_truthy
  end

  it 'knows if a request is not a draft', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    expect(disburser_request_1.draft?).to be_falsy
  end

  it 'knows if a request is a submitted', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    expect(disburser_request_1.submitted?).to be_truthy
  end

  it 'knows if a request is not a submitted', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STAUTS_DRAFT, status_user: @moomintroll_user)
    expect(disburser_request_1.submitted?).to be_falsy
  end

  it 'knows if a request is query fulfilled', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, fulfillment_status: DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, status_user: @moomintroll_user)
    expect(disburser_request_1.query_fulfilled?).to be_truthy
  end

  it 'knows if a request is not query fulfilled', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, fulfillment_status: DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED, status_user: @moomintroll_user)
    expect(disburser_request_1.query_fulfilled?).to be_falsy
  end

  it 'knows if a request is query not started', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.not_started?).to be_truthy
  end

  it 'knows if a request is not not started', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, fulfillment_status: DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, status_user: @moomintroll_user)
    expect(disburser_request_1.not_started?).to be_falsy
  end

  it "saves a disburser request status once the status reaches 'submitted'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request_1.disburser_request_statuses.first.user.username).to eq(@moomintroll_user.username)
  end

  it "saves a disburser request status once the status reaches 'submitted' (but only once)", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request_1.disburser_request_statuses.first.user.username).to eq(@moomintroll_user.username)
    disburser_request_1.title = 'moomin research'
    disburser_request_1.save!
    disburser_request_1.reload
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect(disburser_request_1.disburser_request_statuses.first.user.username).to eq(@moomintroll_user.username)
  end

  it "saves a disburser request status once the fulfillment status reaches 'query fulfilled'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.disburser_request_statuses.size).to eq(0)
    expect(disburser_request_1.fulfillment_status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED)
    disburser_request_1.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
    disburser_request_1.status_user = @little_my_user
    status_comments = 'Moomin fulfilled'
    disburser_request_1.status_comments = status_comments
    disburser_request_1.save!
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)
    expect(disburser_request_1.disburser_request_statuses.first.user.username).to eq(@little_my_user.username)
    expect(disburser_request_1.disburser_request_statuses.first.comments).to eq(status_comments)
  end

  it "saves a disburser request status once the fulfillment status reaches 'query fulfilled'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.disburser_request_statuses.size).to eq(0)
    expect(disburser_request_1.fulfillment_status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED)
    disburser_request_1.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
    disburser_request_1.status_user = @little_my_user
    status_comments = 'Moomin fulfilled'
    disburser_request_1.status_comments = status_comments
    disburser_request_1.save!
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)
    expect(disburser_request_1.disburser_request_statuses.first.user.username).to eq(@little_my_user.username)
    expect(disburser_request_1.disburser_request_statuses.first.comments).to eq(status_comments)
  end

  it "saves a disburser request status once the fulfillment status reaches 'query fulfilled' (only once)", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request_1.disburser_request_statuses.size).to eq(0)
    expect(disburser_request_1.fulfillment_status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_NOT_STARTED)
    disburser_request_1.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
    disburser_request_1.status_user = @little_my_user
    status_comments = 'Moomin fulfilled'
    disburser_request_1.status_comments = status_comments
    disburser_request_1.save!
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
    expect(disburser_request_1.disburser_request_statuses.first.status).to eq(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)
    expect(disburser_request_1.disburser_request_statuses.first.user.username).to eq(@little_my_user.username)
    expect(disburser_request_1.disburser_request_statuses.first.comments).to eq(status_comments)
    disburser_request_1.reload
    disburser_request_1.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
    disburser_request_1.status_user = @little_my_user
    status_comments = 'Moomin fulfilled again'
    disburser_request_1.status_comments = status_comments
    disburser_request_1.save!
    expect(disburser_request_1.disburser_request_statuses.size).to eq(1)
  end

  it "can return disburser requests that do not have a status of 'draft'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure cancer', investigator: 'placehoder', irb_number: 'placehoder', cohort_criteria: 'placehoder', data_for_cohort: 'placehoder')
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure heart disease',  investigator: 'placehoder', irb_number: 'placehoder', cohort_criteria: 'placehoder', data_for_cohort: 'placehoder')
    disburser_request_2.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
    disburser_request_2.status_user = @little_my_user
    disburser_request_2.save!

    expect(DisburserRequest.not_draft).to match_array([disburser_request_2])
  end

  it "can return disburser requests thare are 'reviewable'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, title: 'Cure cancer', investigator: 'placehoder', irb_number: 'placehoder', cohort_criteria: 'placehoder', data_for_cohort: 'placehoder')

    DisburserRequest::DISBURSER_REQUEST_STATUSES.each do |disburser_request_status|
      disburser_request_1.status = disburser_request_status
      disburser_request_1.status_user = @little_my_user
      disburser_request_1.save!

      if DisburserRequest::DISBURSER_REQUEST_STATUSES_REVIEWABLE.include?(disburser_request_status)
        expect(DisburserRequest.reviewable).to match_array([disburser_request_1])
      else
        expect(DisburserRequest.reviewable).to be_empty
      end
    end
  end

  it 'can find or initialize a disburser_request_vote (initialize)', focus: false do
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    disburser_request_vote = disburser_request.find_or_initialize_disburser_request_vote(@little_my_user)
    expect(disburser_request_vote.new_record?).to be_truthy
    expect(disburser_request_vote.committee_member).to eq(@little_my_user)
  end

  it 'can find or initialize a disburser_request_vote (find)', focus: false do
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    disburser_request_vote = FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request,  committee_member: @little_my_user, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE)
    disburser_request_vote_found = disburser_request.find_or_initialize_disburser_request_vote(@little_my_user)
    expect(disburser_request_vote).to eq(disburser_request_vote_found)
  end

  it "can return disburser requests by vote status 'pending my vote'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request_1, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, committee_member: @little_my_user)
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(DisburserRequest.by_vote_status(@little_my_user, DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE)).to match_array([disburser_request_2])
  end

  it "can return disburser requests by vote status 'approved'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request_1, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, committee_member: @little_my_user)
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request_2, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY, committee_member: @little_my_user)
    disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(DisburserRequest.by_vote_status(@little_my_user, DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_APPROVED)).to match_array([disburser_request_1])
  end

  it "can return disburser requests by vote status 'denied'", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request_1, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, committee_member: @little_my_user)
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request_2, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY, committee_member: @little_my_user)
    disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(DisburserRequest.by_vote_status(@little_my_user, DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_DENIED)).to match_array([disburser_request_2])
  end

  it "can return disburser requests by vote status regardless of other committee member votes", focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request_1, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_APPROVE, committee_member: @the_groker_user)
    disburser_request_2 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    FactoryGirl.create(:disburser_request_vote, disburser_request: disburser_request_2, vote: DisburserRequestVote::DISBURSER_REQUEST_VOTE_TYPE_DENY, committee_member: @the_groker_user)
    disburser_request_3 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(DisburserRequest.by_vote_status(@little_my_user, DisburserRequest::DISBURSER_REQUEST_VOTE_STATUS_PENDING_MY_VOTE)).to match_array([disburser_request_1, disburser_request_2, disburser_request_3])
  end

  it 'knows when a request was submitted at', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user)
    disburser_request_status_submitted = disburser_request_1.reload.disburser_request_statuses.detect { |disburser_request_status| disburser_request_status.status == DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED }
    expect(disburser_request_1.submitted_at).to eq(disburser_request_status_submitted.created_at)
  end

  it 'gets the latest status detail by status', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_user: @moomintroll_user, status_comments: 'moomintroll comment')
    disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_COMMITTEE_REVIEW
    disburser_request_1.status_user = @moomintroll_user
    disburser_request_1.status_comments = 'moomintroll comment'
    disburser_request_1.save!
    disburser_request_detail = disburser_request_1.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect({ status_user_name: disburser_request_detail.user.username, status: disburser_request_detail.status, status_comments: disburser_request_detail.comments}).to eq({ status_user_name: @moomintroll_user.username, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_comments: 'moomintroll comment' })
    disburser_request_1.reload
    disburser_request_1.status = DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED
    disburser_request_1.status_user = @little_my_user
    disburser_request_1.status_comments = 'little my comment'
    disburser_request_1.save!
    disburser_request_detail = disburser_request_1.status_detail(DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED)
    expect({ status_user_name: disburser_request_detail.user.username, status: disburser_request_detail.status, status_comments: disburser_request_detail.comments}).to eq({ status_user_name: @little_my_user.username, status: DisburserRequest::DISBURSER_REQUEST_STATUS_SUBMITTED, status_comments: 'little my comment' })
  end

  it 'gets the latest fulfillment status detail by fulfillment status', focus: false do
    disburser_request_1 = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user, fulfillment_status: DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, status_user: @moomintroll_user, status_comments: 'moomintroll comment')
    disburser_request_1.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_INSUFFICIENT_DATA
    disburser_request_1.status_user = @moomintroll_user
    disburser_request_1.status_comments = 'moomintroll comment'
    disburser_request_1.save!
    disburser_request_detail = disburser_request_1.fulfillment_status_detail(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)
    expect({ status_user_name: disburser_request_detail.user.username, status: disburser_request_detail.status, status_comments: disburser_request_detail.comments}).to eq({ status_user_name: @moomintroll_user.username, status: DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, status_comments: 'moomintroll comment' })
    disburser_request_1.reload
    disburser_request_1.fulfillment_status = DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED
    disburser_request_1.status_user = @little_my_user
    disburser_request_1.status_comments = 'little my comment'
    disburser_request_1.save!
    disburser_request_detail = disburser_request_1.fulfillment_status_detail(DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED)
    expect({ status_user_name: disburser_request_detail.user.username, status: disburser_request_detail.status, status_comments: disburser_request_detail.comments}).to eq({ status_user_name: @little_my_user.username, status: DisburserRequest::DISBURSER_REQUEST_FULFILLMENT_STATUS_QUERY_FULFILLED, status_comments: 'little my comment' })
  end

  it 'knows if it is a request for speciemns', focus: false do
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    disburser_request_detail = {}
    disburser_request_detail[:specimen_type] = @specimen_type_blood
    disburser_request_detail[:quantity] = '5'
    disburser_request_detail[:volume] = '10 mg'
    disburser_request_detail[:comments] = 'Moomin specimen'
    specimen_type = @moomin_repository.specimen_types.where(name: @specimen_type_blood).first
    disburser_request.disburser_request_details.build(specimen_type: specimen_type, quantity: disburser_request_detail[:quantity], volume: disburser_request_detail[:volume], comments: disburser_request_detail[:comments])
    disburser_request.save
    expect(disburser_request.specimens?).to be_truthy
  end

  it 'knows if it is not  request for speciemns', focus: false do
    disburser_request = FactoryGirl.create(:disburser_request, repository: @moomin_repository, submitter: @moomintroll_user)
    expect(disburser_request.specimens?).to be_falsy
  end
end