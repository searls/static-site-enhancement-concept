class Cli
  def initialize
    @config = EnhancementConfig.load
    @commands = [
      Commands::UpdatePublishDateCache.new,
      Commands::AddCardsToTakes.new,
      Commands::AdvancePublicationDate.new
    ]
  end

  def check
    if @commands.any? { |command| command.should_run?(@config) }
      exit 0
    else
      exit 1
    end
  end

  def run
    De.bug <<~MSG
      ✨ JUSTIN'S VERY BESPOKE CONTENT ENHANCER ✨

      These commands will be run:

      #{@commands.map { |c| "- #{c.class.name}" }.join("\n")}

    MSG

    @commands.each do |command|
      De.in
      De.bug "Asking #{command.class.name} if it needs to run"
      if command.should_run?(@config)
        De.bug "Running #{command.class.name}"
        command.run(@config)
        if (config_update = command.updated_config(@config))
          De.bug "#{command.class.name} updating config with: #{config_update.inspect}"
          @config = EnhancementConfig.update!(@config, config_update)
        end
        De.bug "Finished running #{command.class.name}"
      else
        De.bug "Skipping #{command.class.name}"
      end
      De.out
    end
  end
end
