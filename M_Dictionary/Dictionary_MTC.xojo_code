#tag Class
Class Dictionary_MTC
Implements Xojo.Core.Iterable
	#tag Method, Flags = &h0
		Sub Clear()
		  dim ub as integer = SlotKeys.Ubound
		  
		  redim SlotKeys( -1 )
		  redim SlotValues( -1 )
		  redim SlotsWithArrays( -1 )
		  mCount = 0
		  
		  RedimArrays( ub )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  FibShifter = 2 ^ ( 64 - SlotUboundExponent )
		  dim ub as integer = ( 2 ^ SlotUboundExponent ) - 1
		  RedimArrays( ub )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetDistribution() As Integer()
		  dim counts() as integer
		  redim counts( SlotKeys.Ubound )
		  
		  for slotIndex as integer = 0 to SlotKeys.Ubound
		    dim slot as variant = SlotKeys( slotIndex )
		    if not slot.IsNull then
		      dim arr() as variant = slot
		      counts( slotIndex ) = arr.Ubound + 1
		    end if
		  next
		  
		  return counts
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetIterator() As Xojo.Core.Iterator
		  dim r as new M_Dictionary.Entry( self )
		  return Xojo.Core.Iterator( r )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasKey(key As Variant) As Boolean
		  dim slotIndex as integer
		  dim itemIndex as integer
		  Locate( key, slotIndex, itemIndex, false )
		  
		  return itemIndex <> -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Keys() As Variant()
		  return SlotsToValues( SlotKeys )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Locate(key As Variant, ByRef slotIndex As Integer, ByRef itemIndex As Integer, raiseException As Boolean = True)
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  const kFibMult as UInt64 = 11400714819323198485
		  
		  dim hash as UInt64 = key.Hash
		  slotIndex = ( hash * kFibMult ) \ FibShifter
		  
		  dim slot as variant = SlotKeys( slotIndex )
		  if slot is nil then
		    itemIndex = -1
		    
		  else
		    //
		    // We have a good slot, let's check the items
		    //
		    dim arrKeys() as variant = slot
		    itemIndex = arrKeys.IndexOf( key )
		  end if
		  
		  if raiseException and itemIndex = -1 then
		    raise new KeyNotFoundException
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Lookup(key As Variant, defaultValue As Variant) As Variant
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  dim slotIndex as integer
		  dim itemIndex as integer
		  Locate( key, slotIndex, itemIndex, false )
		  
		  if itemIndex = -1 then
		    return defaultValue
		  else
		    dim values() as variant = SlotValues( slotIndex )
		    return values( itemIndex )
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RedimArrays(ub As Integer)
		  redim SlotKeys( ub )
		  redim SlotValues( ub )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(key As Variant)
		  dim slotIndex as integer
		  dim itemIndex as integer
		  Locate( key, slotIndex, itemIndex )
		  
		  dim arrKeys() as variant = SlotKeys( slotIndex )
		  arrKeys.Remove itemIndex
		  
		  dim arrValues() as variant = SlotValues( slotIndex )
		  arrValues.Remove itemIndex
		  
		  mCount = mCount - 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SlotsToValues(slotArr() As Variant) As Variant()
		  dim result() as variant
		  redim result( mCount - 1 )
		  dim resultIndex as integer = -1
		  
		  for i as integer = 0 to SlotsWithArrays.Ubound
		    dim slotIndex as integer = SlotsWithArrays( i )
		    dim itemArr() as variant = slotArr( slotIndex )
		    for itemIndex as integer = 0 to itemArr.Ubound
		      resultIndex = resultIndex + 1
		      result( resultIndex ) = itemArr( itemIndex )
		    next
		  next
		  
		  return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(key As Variant) As Variant
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  dim slotIndex as integer
		  dim itemIndex as integer
		  Locate( key, slotIndex, itemIndex )
		  
		  dim arr() as variant = SlotValues( slotIndex )
		  return arr( itemIndex )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Value(key As Variant, Assigns value As Variant)
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  dim slotIndex as integer
		  dim itemIndex as integer
		  Locate( key, slotIndex, itemIndex, false )
		  
		  if itemIndex = -1 then
		    dim slot as variant = SlotKeys( slotIndex )
		    
		    if slot is nil then
		      SlotKeys( slotIndex ) = array( key )
		      SlotValues( slotIndex ) = array( value )
		      
		      SlotsWithArrays.Append slotIndex
		    else
		      dim arrKeys() as variant = slot
		      arrKeys.Append key
		      
		      dim arrValues() as variant = SlotValues( slotIndex )
		      arrValues.Append value
		    end if
		    
		    mCount = mCount + 1
		    
		  else
		    //
		    // Replace the item
		    //
		    dim arr() as variant = SlotValues( slotIndex )
		    arr( itemIndex ) = value
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Values() As Variant()
		  return SlotsToValues( SlotValues )
		  
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mCount
			End Get
		#tag EndGetter
		Count As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private FibShifter As UInt64
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SlotKeys() As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SlotsWithArrays() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SlotUboundExponent As Integer = 12
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SlotValues() As Variant
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Count"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
