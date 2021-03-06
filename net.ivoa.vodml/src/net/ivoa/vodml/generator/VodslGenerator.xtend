/**
 * generated by Xtext - then hand edited by Paul Harrison.
 */
package net.ivoa.vodml.generator

import org.eclipse.emf.ecore.resource.Resource
import net.ivoa.vodml.vodsl.IncludeDeclaration
import net.ivoa.vodml.vodsl.PackageDeclaration
import net.ivoa.vodml.vodsl.ObjectType
import net.ivoa.vodml.vodsl.Enumeration
import net.ivoa.vodml.vodsl.DataType
import net.ivoa.vodml.vodsl.PrimitiveType
import net.ivoa.vodml.vodsl.VoDataModel
import net.ivoa.vodml.vodsl.EnumLiteral
import net.ivoa.vodml.vodsl.Attribute
import net.ivoa.vodml.vodsl.Constraint
import net.ivoa.vodml.vodsl.Multiplicity
import net.ivoa.vodml.vodsl.ReferableElement
import java.util.TimeZone
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date
import net.ivoa.vodml.vodsl.Reference
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.generator.IFileSystemAccess2
import net.ivoa.vodml.vodsl.Composition
import java.util.List
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.IQualifiedNameConverter
import net.ivoa.vodml.vodsl.SubSet

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class VodslGenerator extends AbstractGenerator  {

    @Inject extension IQualifiedNameProvider	
    @Inject IQualifiedNameConverter converter 
	 static val TimeZone tz = TimeZone.getTimeZone("UTC")
    static val DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
    new()
    {
    	df.setTimeZone(tz)
    }
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val vodecl = resource.allContents.filter(typeof(VoDataModel)).head // surely there must be a better way of getting this one....
		val modelDecl = vodecl.model
		val filenameFull = resource.URI.lastSegment
		val filename = filenameFull.substring(0,filenameFull.lastIndexOf('.')) +  '.vo-dml.xml'
		fsa.generateFile(filename, vodecl.vodml)
	}
	
	
	def vodml(VoDataModel e)'''
<?xml version="1.0" encoding="UTF-8"?>
<vo-dml:model xmlns:vo-dml="http://www.ivoa.net/xml/VODML/v1" version="1.0"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.ivoa.net/xml/VODML/v1 http://volute.g-vo.org/svn/trunk/projects/dm/vo-dml/xsd/vo-dml-v1.0.xsd">	<!-- file generated from VODSL -->
      <name>«e.model.name»</name>
      <description>«e.model.description»</description> 
      <uri/>
      <title>TBD</title>
      «FOR a:e.model.authors»
        <author>«a»</author>
      «ENDFOR»
      <version>«e.model.version»</version>
      <lastModified>«df.format(new Date())»</lastModified>
      «FOR f:e.includes»
      	«f.vodml»
      «ENDFOR» 
      «e.elements.vodml»
</vo-dml:model>
	'''
	
	
	def vodml(IncludeDeclaration e) '''
	<import>
	  <name>tbd</name><!--should be able to work out from the included model -->
	  <url>«e.importURI.substring(0,e.importURI.lastIndexOf('.')) +'.vo-dml.xml'»</url>
	  <documentationURL>not known</documentationURL>
	</import>
	'''
	
	def vodml(ReferableElement e)
	{
      //shame that xtend does not do dynamic dispatch - at least not in the way that I thought....
      switch  e {
      	PackageDeclaration : (e as PackageDeclaration).vodml
      	ObjectType : (e as ObjectType).vodml
      	Enumeration : (e as Enumeration).vodml
      	DataType : (e as DataType).vodml
      	PrimitiveType: (e as PrimitiveType).vodml
      	Attribute: (e as Attribute).vodml
      	default: "unknown type " + e.class
      }
      		
 
	}
	
	def preamble(ReferableElement e) '''
	   <vodml-id>«e.fullyQualifiedName.skipFirst(1)»</vodml-id>
	   <name>«e.name»</name>
	   <description>«e.description»</description>	    
	'''
	
	
	def vodml(List<ReferableElement> e) '''
	   «FOR f: e.filter(PrimitiveType)»
         «(f as PrimitiveType).vodml»
      «ENDFOR»
      «FOR f: e.filter(Enumeration)»
         «(f as Enumeration).vodml»
      «ENDFOR»
      «FOR f: e.filter(DataType)»
         «(f as DataType).vodml»
      «ENDFOR»
      «FOR f: e.filter(ObjectType)»
         «(f as ObjectType).vodml»
      «ENDFOR»
      «FOR f: e.filter(PackageDeclaration)»
         «(f as PackageDeclaration).vodml»
      «ENDFOR»		
'''	
	
	def vodml (PackageDeclaration e)'''
	<package>
	   «e.preamble»
      «e.elements.vodml»
	</package>
	'''
	def vodml (ObjectType e)'''
	<objectType«IF e.abstract» abstract='true'«ENDIF»>
	   «e.preamble»
	   «IF e.superType != null»
	   <extends>
	      «(e.superType as ReferableElement).ref»
	   </extends>
	   «ENDIF»
	   «FOR f: e.constraints»
	   	«f.vodml»
	   «ENDFOR»
	   «FOR f: e.subsets»
	   	«f.vodml»
	   «ENDFOR»	   
	   «FOR f: e.content.filter(Attribute)»
	   	«(f as Attribute).vodml»
	   «ENDFOR»
	   «FOR f: e.content.filter(Composition)»
	   	«(f as Composition).vodml»
	   «ENDFOR»	   
	   «FOR f: e.content.filter(Reference)»
	   	«(f as Reference).vodml»
	   «ENDFOR»	   
	</objectType>
	'''
	def vodml (Attribute e)'''
	<attribute>
	  «e.preamble»
	  <datatype>
	     «(e.type as ReferableElement).ref»
	  </datatype>
	  «vodml(e.multiplicity)»
	</attribute>
	'''
	
	def vodml (Composition e)
	'''
	<composition>
	  «e.preamble»
	  <datatype>
	     «(e.type as ReferableElement).ref»
	  </datatype>
	  «vodml(e.multiplicity)»
	  «IF e.isOrdered»<isOrdered>true</isOrdered>«ENDIF»
	</composition>
	'''
	

   def ref(ReferableElement e)'''
   <vodml-ref>«converter.toString(e.fullyQualifiedName)»</vodml-ref>
   '''

   def vodml(Reference e)'''
   <reference>
     «e.preamble»
     <datatype>
       «(e.type as ReferableElement).ref»
     </datatype>
     «vodml(e.multiplicity)»
   </reference>
   '''
   
// FIXME this is not really doing correct thing for attributes yet...
   def vodml(Constraint e)'''
   <constraint>
      «IF e.expr != null»
        <expression>«e.expr»</expression>
        <language>«e.language»</language>
      «ENDIF»
   </constraint>
   '''


	def vodml (Enumeration e)'''
	<enumeration>
	   «e.preamble»
      «FOR f: e.literals»
         «f.vodml»
      «ENDFOR»
	</enumeration>
	'''
	def vodml (DataType e)
	'''
	<dataType«IF e.abstract» abstract='true'«ENDIF»>
	  «e.preamble»
	   «IF e.superType != null»
	   <extends>
	      «(e.superType as ReferableElement).ref»
	   </extends>
	   «ENDIF»
	   «FOR f: e.constraints»
	   	«f.vodml»
	   «ENDFOR»
      «FOR f: e.content.filter(Attribute)»
	   	«(f as Attribute).vodml»
	   «ENDFOR»
	   «FOR f: e.content.filter(Reference)»
	   	«(f as Reference).vodml»
	   «ENDFOR»	   	
	</dataType>
	'''
	
	def vodml (Multiplicity e)
	{
		if (e !== null)
		{
			if(e.multiplicitySpec !== null)
			{
				switch e.multiplicitySpec {
					case ATLEASTONE: {
						vodml(1,-1)
					}
					case MANY: {
						vodml(0,-1)
					}
					case OPTIONAL: {
						vodml(0,1)
					}
					case ONE:
					{
						if(e.minOccurs != 0)
						{
							vodml(e.minOccurs, e.maxOccurs)
						}
						else
						{
							vodml(1,1)
						}
					}
					default:
						vodml(1,1)
					
				}
			}
			else
			{
				vodml(e.minOccurs, e.maxOccurs)
			}
		}
		else
		{
		vodml(1, 1)
		}
	}
	
	def vodml(int minOccurs, int maxOccurs)'''
	<multiplicity>
	  <minOccurs>«minOccurs»</minOccurs>
	  <maxOccurs>«maxOccurs»</maxOccurs>
	</multiplicity>
	'''
	
	
	def vodml (PrimitiveType e)'''
   <primitiveType>
     «e.preamble»
   </primitiveType>
	'''
	def vodml (EnumLiteral e)'''
   <literal>
     «e.preamble»
   </literal>	
	'''
	
	def vodml(SubSet e)'''
	<constraint xsi:type="vo-dml:SubsettedRole">
	   <role>
	      «(e.ref as ReferableElement).ref»
	   </role>
	   <datatype>
	      «(e.type as ReferableElement).ref»
	   </datatype>
	</constraint>
	'''
}
