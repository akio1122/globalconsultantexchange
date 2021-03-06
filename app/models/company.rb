class Company < ActiveRecord::Base
  GLOBAL_CONSULTANT_EXCHANGE = 'Global Consultant Exchange'
  GCES_FEE = 10

  belongs_to :owner, class_name: 'User', inverse_of: :owned_company, dependent: :delete
  has_many :users, dependent: :destroy
  accepts_nested_attributes_for :owner

  has_one :invite_user, class_name: 'InviteUser', dependent: :delete
  accepts_nested_attributes_for :invite_user

  mount_uploader :contract, ResumeUploader, mount_on: :contract_file_name

  validates :company_name, length: { in: 2..512 }, presence: true
  # validates :owner, presence: true
  validates :first_name, length: { in: 2..24 }, presence: true,
            format: { with: RegexConstants::Letters::AND_NUMBERS,
                      message: I18n.t('activerecord.errors.messages.regex.only_letters_numbers') }
  validates :last_name, length: { in: 2..24 }, presence: true,
            format: { with: RegexConstants::Words::AND_SPECIAL,
                      message: I18n.t('activerecord.errors.messages.regex.only_letters_numbers') }

  validates :phone,
            presence: true,
            format:   {
                with:    RegexConstants::Phone::PHONE_NUMBER,
                message: I18n.t('activerecord.errors.messages.regex.phone')
            }
  validates :contract_start, presence: true, date: { on_or_after: DateTime.now }
  validates :contract_end, presence: true, date: { on_or_after: :contract_start }
  validates :contract,
            file_size: { less_than: 10.megabytes },
            file_content_type: { allow: RegexConstants::FileTypes::AS_DOCUMENTS }

end
