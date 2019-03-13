class EventImportJob < ApplicationJob
  queue_as :default

  def perform(metro_area)
    logger.info "Starting Job: Event Import for : #{metro_area}"
    ticketmaster_service = TicketmasterService.new
    ticketmaster_service.import_events(metro_area)
    logger.info "Finishing Job: Event Import for : #{metro_area}"
  end
end
