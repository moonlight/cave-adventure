--
-- This file contains the action controller. Other scripts
-- can add actions to the controller, which will execute in
-- parralel. The actions are defined elsewhere.
--
-- By Bj�rn Lindeijer

ActionController =
{
	-- A wrapper to put a sequence of actions automatically in a sequence.
	addSequence = function(self, seq)
		return self:addAction(ActionSequence(seq))
	end;

	-- Adds a single action to the list of actions to execute.
	addAction = function(self, action)
		if (action:instanceOf(Action)) then
			-- Create an action execution environment for this action
			local execEnv = {}
			setmetatable(execEnv, {__index = action})
			execEnv._id = self.actionId
			self.actionId = self.actionId + 1

			-- Insert the action execution environment in the actions array
			table.insert(self.actions, execEnv)

			-- Return the environment, as that can be used to remove the action
			return execEnv
		else
			m_message("addAction(): action not an instance of Action (".. action.name ..")")
		end
	end;

	-- Removes the specified sequence/action according to the execution environment.
	removeSequence = function(self, execEnv)
		if (execEnv) then
			for i = 1, table.getn(self.actions) do
				if (self.actions[i] == seq) then
					table.remove(self.actions, i)
				end
			end
		end
	end;

	-- Update executes the active actions.
	update = function(self)
		local i

		-- Execute all running actions
		for i = 1, table.getn(self.actions) do
			if (i <= table.getn(self.actions) and self.actions[i]:exec()) then
				m_message("Finished executing "..self.actions[i].name .." (".. self.actions[i]._id ..")")
				table.remove(self.actions, i)
				i = i - 1
			end
		end
	end;

	actions = {};
	actionId = 1;
}
