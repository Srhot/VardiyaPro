# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@vardiyapro.com'
  layout 'mailer'
end
