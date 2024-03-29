require './lib/ldap'
class NorthwesternUser < User
  devise :ldap_authenticatable, :trackable, :timeoutable

  #Class Methods
  def self.search(search_token, repository = nil)
    all_users = []
    search_tokens = search_token.split(' ')
    st = search_tokens.shift
    all_users = find_ldap_entries_by_name(st)
    search_tokens.each do |st|
      users = find_ldap_entries_by_name(st)
      all_users = users & all_users
    end

    if repository
      existing_users = repository.repository_users.map { |repository_user| { username: repository_user.user.username, first_name: repository_user.user.first_name, last_name: repository_user.user.last_name, email: repository_user.user.email } }
      all_users = all_users - existing_users
    end

    all_users
  end

  def self.extract_uid_from_dn(dn)
    dn.match(/(?<=uid=)(\w*)(?=,)/).to_s
  end

  def self.find_ldap_entry_by_username(username)
    user = Ldap.instance.find_entry_by_netid(username)
    if user
      user = { username: NorthwesternUser.extract_uid_from_dn(user.dn), first_name: user.givenname.first, last_name: user.sn.first, email: user.mail.first }
    else
      user = {}
    end
    user
  end

  def self.find_ldap_entries_by_name(search_token)
    users = Ldap.instance.find_entries_by_name("#{search_token}*").map { |user| { username: NorthwesternUser.extract_uid_from_dn(user.dn), first_name: user.givenname.first, last_name: user.sn.first, email: user.mail.first } }
  end

  private_class_method :find_ldap_entries_by_name

  #Instance Methods
  def hydrate_from_ldap
    if !Rails.env.development?
      user = NorthwesternUser.find_ldap_entry_by_username(self.username)
      if user
        self.first_name = user[:first_name]
        self.last_name = user[:last_name]
        self.email = user[:email]
      end
    end
  end

  def after_ldap_authentication
    login_audit = LoginAudit.new(user: self)
    login_audit.save!
    hydrate_from_ldap
  end
end