module UnreadIssues
  module UsersControllerPatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)	

		base.class_eval do

		end
		
    end
	
	module ClassMethods   
		def count_issues
		end
	end
	
	module InstanceMethods
	
	end
	
  end
end
