class Host < ActiveRecord::Base
  belongs_to :site
  has_many :hits
  has_many :host_paths
  has_many :daily_hit_totals

  validate :hostname, presence: true
  validate :site, presence: true

  def aka_hostname
    # This does the reverse of Bouncer's aka handling:
    #     hostname.sub(/^aka-/, '').sub(/^aka\./, 'www.')
    if hostname.start_with?('www.')
      hostname.sub(/^www\./, 'aka.')
    else
      'aka-' + hostname
    end
  end

  def self.canonical_hostname(hostname)
    hostname.sub(/^aka-/, '').sub(/^aka\./, 'www.')
  end

  def redirected_by_gds?
    /^redirector-cdn[^.]*\.production\.govuk\.service\.gov\.uk$/.match(cname).present?
  end
end
