-- seq_control.lua
--
-- This file contains the sequence controller. Other scripts
-- can add sequences to the controller, which will execute in
-- parralel. A sequence can be viewed as an array of actions.
-- The actions are defined elsewhere.
--
-- By Bjørn Lindeijer

SeqControl = {
	active_seqs = {},
	nextSeqId = 1,
}


function SeqControl:add_sequence(new_seq)
	if (not new_seq) then m_message("Error: SeqControl:add_sequence() called with nil value!") end

	if (table.getn(new_seq) > 0) then
		-- Copy the array of action definitions, so that the original
		-- can be reused.
		local actions = {}
		for i = 1, table.getn(new_seq) do
			local action = {}
			inherit(action, new_seq[i])
			table.insert(actions, action)
		end

		-- Assign unique sequence ID
		actions.seqId = self.nextSeqId
		self.nextSeqId = self.nextSeqId + 1

		-- Add the sequence to the active sequence array
		table.insert(self.active_seqs, actions)
		--m_message("Sequence of "..table.getn(actions).." actions added (".. actions.seqId ..").")

		-- Return a reference to the added sequence
		return actions
	end
end

function SeqControl:remove_sequence(seq)
	if (not seq) then return end
	--m_message("SeqControl:remove_sequence() called (".. seq.seqId ..").")

	for i = 1, table.getn(self.active_seqs) do
		if (self.active_seqs[i] == seq) then
			--m_message("Removing found sequence (".. seq.seqId ..").")
			table.remove(self.active_seqs, i)
		end
	end
end


function SeqControl:update()
	local i

	for i = 1, table.getn(self.active_seqs) do
		-- Remove any finished actions
		while (table.getn(self.active_seqs[i]) > 0 and self.active_seqs[i][1]:finished()) do
			--m_message("Finished executing action "..self.active_seqs[i][1].name .." (".. self.active_seqs[i].seqId ..")")
			table.remove(self.active_seqs[i], 1)
		end

		-- Handle first non-finished action
		if (table.getn(self.active_seqs[i]) > 0) then
			local action = self.active_seqs[i][1]
			--m_message("Executing action "..action.name)
			action:exec()
		end
	end
	for i = 1, table.getn(self.active_seqs) do
		-- Remove sequence when no actions remain
		if (table.getn(self.active_seqs[i]) == 0) then
			table.remove(self.active_seqs, i)
			return
		end
	end
end