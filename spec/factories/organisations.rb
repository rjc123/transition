FactoryGirl.define do
  factory :organisation do
    title 'Orgtastic'
    launch_date { 1.month.ago }

    ga_profile_id '46600000'
    whitehall_type 'Executive non-departmental public body'
  end
end
