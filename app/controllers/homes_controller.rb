class HomesController < ApplicationController

  before_filter :require_login

  def edit
    @is_semis_session = session[:is_semis_session]
    @team = Team.find(session[:team_id])
    @best = @team.best_score
    @design = Design.new
  end

  def update
    @is_semis_session = session[:is_semis_session]

    # Get the team and grab a lock if a design was submitted.
    @team = Team.find(session[:team_id], :lock => !params[:design].blank?)

    # If logout...
    if params.nonblank? :logout
      kill_session "You've logged out!"

    # Else if update contact information...
    elsif params.nonblank? :update_contact
      case @team.category
        when 'e'
          redirect_to :controller => :captain_completions, :action => :edit
        when 'i'
          redirect_to :controller => :team_completions, :action => :edit
        else
          kill_session 'System error. Please try again.'
      end

    # Else if get standings...
    elsif params.nonblank? :get_standings
      @best = @team.best_score
      @design = Design.new
      @standing, @out_of = Standing.standing(@team)
      @result = :get_standings
      render 'edit'

    # Else if a design was uploaded.
    elsif params.nonblank? :design

      # This should never happen because the upload box is not visible.
      # But someone could get clever with a script.
      if @team.rejected?
        kill_session "Your team is disqualified and cannot submit a design."
        return
      end

      # Approach here is to fill the @analysis hash and @result with all information
      # and leave decisions on how to present it to the view.
      @best = @team.best_score

      # There is a design from the user.  Read the uploaded string.
      bridge = params[:design][:bridge].read

      # Descramble and analyze.
      WPBDC.endecrypt(bridge)
      @analysis = WPBDC.analyze(bridge)

      # Catch uploads of the wrong scenario during semi-finals.
      if session[:is_semis_session] && @analysis[:scenario] != WPBDC::SEMIFINAL_SCENARIO_ID
        @result = :not_semis_scenario
      elsif !session[:is_semis_session] && @analysis[:scenario] == WPBDC::SEMIFINAL_SCENARIO_ID
        @result = :bad_semis_scenario
      else
        case @analysis[:status]

          when WPBDC::BRIDGE_OK

            # Check for duplicates. Do hash check first to weed out most possibilities and then formal comparison.
            if Design.find_all_by_hash_string(@analysis[:hash]).any? { |d| WPBDC.are_same(bridge, d.bridge) }
              @standing, @out_of = Standing.interpolated_standing(@team, @analysis[:score])
              @result = :duplicate
            else
              # Check for improvement.
              @best_for_scenario = @team.best_score_for_scenario(@analysis[:scenario])

              if @best_for_scenario.nil? || @analysis[:score] < @best_for_scenario

                # For semi-finals update messages.
                @old_best_for_scenario = @best_for_scenario
                @best_for_scenario = @analysis[:score]

                # We have a valid improvement. Build a new design model instance.
                sequence = SequenceNumber.get_next(:design)
                logger.info "Analysis for save: #{@analysis.inspect}"
                @design = @team.designs.build(:score => @analysis[:score],
                                              :sequence => sequence,
                                              :scenario => @analysis[:scenario],
                                              :hash_string => @analysis[:hash],
                                              :bridge => bridge)
                if @design.save
                  @team.submits = @team.submits + 1
                  # Put this design in the standings.
                  if @best.nil? || @analysis[:score] < @best
                    @old_best = @best
                    @best = @analysis[:score]
                    @team.improves = @team.improves + 1
                    Team.increment_counter :improves, @team.id
                    @standing, @out_of = Standing.insert(@team, @design)
                    logger.info "Inserted standing #{@standing} of #{@out_of}."
                    @result = :new_best
                  else
                    @result = :not_new_best
                  end
                  # TODO I don't think there's anything to save here!
                  # @team.save!
                else
                  logger.error "design save failed #{@design.errors.messages.inspect}: #{@design.inspect}"
                  @result = :save_failed
                end

              else
                @result = :no_improvement
              end
            end
          when WPBDC::BRIDGE_MALFORMED
            @result = :bridge_malformed
          when WPBDC::BRIDGE_WRONGVERSION
            @result = :bridge_wrong_version
          when WPBDC::BRIDGE_FAILEDTEST
            @result = :bridge_failed_test
        end
      end
      # Edit view responds to @is_semis_session, @team, @analysis, and @design.
      @design ||= Design.new
      render 'edit'
    else
      # It was the main submit button, but no design was submitted.
      @design = Design.new
      @result = :no_bridge
      render 'edit'
    end
  end

end