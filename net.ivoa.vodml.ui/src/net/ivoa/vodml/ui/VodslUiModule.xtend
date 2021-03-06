/*
 * generated by Xtext 2.9.1
 */
package net.ivoa.vodml.ui

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import com.google.inject.Binder
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class VodslUiModule extends AbstractVodslUiModule {
	
	override configure(Binder binder) {
		super.configure(binder)
		//have to use binder directly because of @implemetedBy in the main xtext code....
		binder.bind(IEObjectDocumentationProvider).to(VodslEobjectDocumentationProvider)
	}
			
}
