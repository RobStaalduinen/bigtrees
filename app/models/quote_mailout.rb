class QuoteMailout
  MAIL_TYPES = {
    quote: 'quote',
    final: 'final',
    followup: 'followup',
    team: 'team'
  }

  def self.post_process_for_type(mail_type, estimate)
    if mail_type == MAIL_TYPES[:followup]
      estimate.update(is_unknown: true)
    elsif mail_type == MAIL_TYPES[:quote]
      estimate.update(quote_sent_date: Date.today)
    end
  end
end
