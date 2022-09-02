class SendgridMailer
  include SendGrid

  def initialize
    @sendgrid = SendGrid::API.new(api_key: Rails.application.credentials[Rails.env.to_sym][:sendgrid_api_key])
  end

  def send(to, template_data, template_id)
    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": "marisa@hoplinmedia.com"
            }
          ],
          "dynamic_template_data": template_data
        }
      ],
      "from": {
        "email": "info@concertwire.live",
        "name": "ConcertWire"
      },
      "template_id": template_id
    }

    begin
        response = @sendgrid.client.mail._("send").post(request_body: data)
    rescue Exception => e
        Rails.logger.info e.message
    end
    Rails.logger.info "Sendgrid status code:"
    Rails.logger.info response.status_code
  end
end