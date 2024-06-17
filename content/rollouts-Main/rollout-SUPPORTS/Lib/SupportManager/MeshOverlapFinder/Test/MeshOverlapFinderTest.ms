clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../MeshOverlapFinder.ms" )	--"./../MeshOverlapFinder.ms"


delete objects

obj = Teapot()

pos = [ 0, 0, 0 ]

test_objects = for i = 1 to 3 collect
(
	pos.x += i * 15

	format "pos: %\n" pos

	_sphere = Sphere radius:20 pos:pos

	_sphere --return
)


MeshOverlapFinder 	= MeshOverlapFinder_v(obj)

MeshOverlapFinder.findOverlaps(test_objects)
