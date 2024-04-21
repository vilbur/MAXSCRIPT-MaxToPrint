clearListener(); print("Cleared in:\n"+getSourceFileName())



/** Merge bit arrays with shared bits
 */
function mergeBitArraysWithSharedBits bitarrays =
(
	--format "\n"; print ".mergeBitArraysWithSharedBits()"

	/** Merge bit arrays in bit array
	 */
	function mergeBitArraysInBitArray bit_array bitarrays_merged matches =
	(
		--format "\n"; print ".mergeBitArraysInBitArray()"
		for m = matches.count to 1 by -1 do
		(
			bit_array += bitarrays_merged[matches[m]]

			deleteItem bitarrays_merged matches[m]
		)

		append bitarrays_merged bit_array

		bitarrays_merged --return
	)

	bitarrays_merged = #(  )


	for bit_array in bitarrays do
	(
		format "\n--------------------\n"
		format "bit_array: %\n" bit_array

		matches =  for i = 1 to bitarrays_merged.count where not ( bit_array * bitarrays_merged[i] ).isEmpty collect i

		format "matches: %\n" matches

		case matches.count  of
		(
			/* ADD NEW BITARRAY */
			(0):	append bitarrays_merged bit_array

			/* JOIN TO EXISTING BITARRAY */
			(1): bitarrays_merged[matches[1]] += bit_array

			/*  (matches.count > 1)  MERGE MULTIPLE BITARRAYS if more than one amtch found */
			default: bitarrays_merged = mergeBitArraysInBitArray(bit_array)(bitarrays_merged)(matches)
		)


	)

	bitarrays_merged --return
)
f


bitarrays = #( #{1..3},  #{ 5..6, 8..9 },  #{3..5}, #{ 10..14 }, #{ 14..17 }, #{ 18..20 }  )



bitarrays_merged = mergeBitArraysWithSharedBits( bitarrays )
format "bitarrays_merged: %\n" bitarrays_merged -- EXPECTED RESULT: #( #{ 1..6, 8..9 }, #{ 10..17 }, #{ 18..20 } )
