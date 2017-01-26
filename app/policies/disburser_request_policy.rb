class DisburserRequestPolicy < ApplicationPolicy
  def data_coordinator?
    user.data_coordinator?
  end

  def specimen_coordinator?
    user.specimen_coordinator?
  end

  def admin?
    user.system_administrator || user.repository_administrator?
  end

  def edit?
    record.mine?(user)
  end

  def update?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user)
  end

  def download_file?
    user.system_administrator || record.repository.repository_administrator?(user) || record.mine?(user) || record.repository.repository_coordinator?(user)
  end

  def edit_admin_status?
    user.system_administrator || record.repository.repository_administrator?(user)
  end

  def edit_data_status?
    record.repository.data_coordinator?(user)
  end

  def edit_specimen_status?
    record.repository.specimen_coordinator?(user)
  end

  def admin_status?
    user.system_administrator || record.repository.repository_administrator?(user)
  end

  def data_status?
    record.repository.data_coordinator?(user)
  end

  def specimen_status?
    record.repository.specimen_coordinator?(user)
  end
end