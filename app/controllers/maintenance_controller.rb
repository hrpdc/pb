# app/controllers/admin/maintenance_controller.rb
class Admin::MaintenanceController < Admin::BaseController
  before_action :require_superadmin!

  def purge_knapsack
    election = Election.find(params[:id])

    ActiveRecord::Base.transaction do
      # Delete all knapsack votes tied to this election (fast, SQL-side)
      ActiveRecord::Base.connection.execute(<<~SQL)
        DELETE FROM vote_knapsacks
        USING voters
        WHERE vote_knapsacks.voter_id = voters.id
          AND voters.election_id = #{election.id}
      SQL

      # Then delete all voters for this election
      Voter.where(election_id: election.id).delete_all
    end

    redirect_to admin_election_path(election),
                notice: "Purged knapsack votes & voters for election #{election.id}."
  end
end

