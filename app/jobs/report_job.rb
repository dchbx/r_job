class ReportJob < RocketJob::Job
  self.destroy_on_complete = false

  def perform
    puts "Hello World" 
  end
end