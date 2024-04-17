/** Source object
 */
struct SourceObject_v
(
	/* construct */


	/* properties */


	/* dependency */
	/* reference */
	/* inhered */



	private


	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
