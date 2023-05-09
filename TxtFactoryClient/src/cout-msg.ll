122:                                              ; preds = %121, %119
  %123 = call noundef nonnull align 4 dereferenceable(4) %"class.std::basic_ostream"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream"* noundef nonnull align 4 dereferenceable(4) @_ZSt4cout, i8* noundef getelementptr inbounds ([6 x i8], [6 x i8]* @.str.221, i32 0, i32 0)), !dbg !73139
  %124 = bitcast %"class.std::shared_ptr.41"* %1 to %"class.std::__shared_ptr_access.43"*, !dbg !73140
  %125 = call noundef %"class.mqtt::message"* @_ZNKSt19__shared_ptr_accessIKN4mqtt7messageELN9__gnu_cxx12_Lock_policyE2ELb0ELb0EEptEv(%"class.std::__shared_ptr_access.43"* noundef nonnull align 1 dereferenceable(1) %124) #3, !dbg !73140
  call void @_ZNK4mqtt7message9to_stringB5cxx11Ev(%"class.std::__cxx11::basic_string"* sret(%"class.std::__cxx11::basic_string") align 4 %4, %"class.mqtt::message"* noundef nonnull align 4 dereferenceable(48) %125), !dbg !73141
  %126 = invoke noundef nonnull align 4 dereferenceable(4) %"class.std::basic_ostream"* @_ZStlsIcSt11char_traitsIcESaIcEERSt13basic_ostreamIT_T0_ES7_RKNSt7__cxx1112basic_stringIS4_S5_T1_EE(%"class.std::basic_ostream"* noundef nonnull align 4 dereferenceable(4) %123, %"class.std::__cxx11::basic_string"* noundef nonnull align 4 dereferenceable(24) %4)
          to label %127 unwind label %165, !dbg !73142
