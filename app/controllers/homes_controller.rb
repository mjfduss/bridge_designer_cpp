class HomesController < ApplicationController

  def edit
    @team = Team.find(params[:id])
    @design = Design.new
  end

  def update
    @team = Team.find(params[:id])

    # If logout...
    if !params[:logout].blank?
      redirect_to :controller => :sessions, :action => :new

    # Else if update contact information...
    elsif !params[:update_contact].blank?
      c = @team.category == 'i' ? :team_completions : :captain_completions
      redirect_to :controller => c, :action => :edit

    # Else if get standings...
    elsif !params[:get_standings].blank?
      @best = @team.best_score
      @design = Design.new
      (@standing, @out_of) = Standing.standing(@team)
      @result = :get_standings
      render 'edit'

    # Else if a design was uploaded.
    elsif !params[:design].blank?

      # There is a design from the user.  Read the uploaded string.
      bridge = params[:design][:bridge].read

      # Current best is always needed.
      @best = @team.best_score

      # Descramble and analyze.
      WPBDC.endecrypt(bridge)
      @analysis = WPBDC.analyze(bridge)

      # Approach here is to fill the @analysis with all information
      # and leave decisions on how to present it to the view.
      case @analysis[:status]
        when WPBDC::BRIDGE_OK

          # Check for duplicates. Do hash check first to weed out most possibilities and then formal comparison.
          hash_matches = Design.where(:hash_string => @analysis[:hash])
          dups = hash_matches.select{ |d| WPBDC.are_same(bridge, d.bridge) }
          if dups.empty?

            # Check for improvement.
            @best_for_scenario = @team.best_score_for_scenario(@analysis[:scenario])

            if @best_for_scenario.nil? || @analysis[:score] < @best_for_scenario

              # No duplicate. Build a new design model instance.
              sequence = SequenceNumber.get_next(:design)
              logger.info "Analysis: #{@analysis.inspect}"
              @design = Design.create(:team_id => params[:id],
                                      :score => @analysis[:score],
                                      :sequence => sequence,
                                      :scenario => @analysis[:scenario],
                                      :hash_string => @analysis[:hash],
                                      :bridge => bridge)
              if @design.save
                Team.increment_counter :submits, @team.id

                # Put this design in the standings.
                if @best.nil? || @analysis[:score] < @best
                  @old_best = @best
                  @best = @analysis[:score]
                  Team.increment_counter :improves, @team.id
                  (@standing, @out_of) = Standing.insert(@team, @design)
                  logger.info "Inserted standing #{@standing} of #{@out_of}."
                  @result = :new_best
                else
                  @result = :not_new_best
                end
              else
                logger.error "design save failed: #{@design.inspect}"
                add_flash :error, "Your bridge could not be saved. Please try again later."
                @result = :save_failed
              end

            else
              @result = :no_improvement
            end
          else
            @design = Design.new
            (@standing, @out_of) = Standing.interpolated_standing(@team, @analysis[:score])
            @result = :duplicate
          end
        when WPBDC::BRIDGE_MALFORMED
          @design = Design.new
          @result = :bridge_malformed
        when WPBDC::BRIDGE_WRONGVERSION
          @design = Design.new
          @result = :bridge_wrong_version
        when WPBDC::BRIDGE_FAILEDTEST
          @design = Design.new
          @result = :bridge_failed_test
      end
      # Edit view responds to contents of @team, @analysis, and @design.
      render 'edit'
    else
      # It was the main submit button, but no design was submitted.
      @design = Design.new
      @result = :no_bridge
      render 'edit'
    end
  end

end