class CreateIssueReads < ActiveRecord::Migration
	def change
	    create_table :issue_reads do |t|
	    	t.references :user
	    	t.references :issue
		    t.datetime :read_date
		    t.timestamps
		end
	end
end
