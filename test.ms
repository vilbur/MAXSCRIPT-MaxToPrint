
clearListener(); print("Cleared in:\n"+getSourceFileName())



MyRay = Ray [0,0,0] [0,0,1]
--intersection = intersectRay $ MyRay
intersection = IntersectRayEx $ MyRay
--hits = intersection.pos

format "intersection: %\n" intersection
--format "hits: %\n" hits

--
--fn selectIntersectVerts obj1 obj2 = if intersects obj1 obj2 do
--(
--	local tempMeshes = #()
--
--	with redraw off undo off
--	(
--		tempMeshes[1] = snapShot obj1
--		addmodifier tempMeshes[1] (Vol__Select level:1 volume:3 node:obj2)
--
--		obj1.selectedverts = tempMeshes[1].selectedverts
--
--		tempMeshes[2] = snapShot obj2
--		addmodifier tempMeshes[2] (Vol__Select level:1 volume:3 node:obj1)
--
--		obj2.selectedverts = tempMeshes[2].selectedverts
--
--		delete tempMeshes
--	)
--)
--
--selectIntersectVerts selection[1] selection[2]
