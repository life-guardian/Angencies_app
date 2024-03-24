String? validateTextField(value, String? label) {
  if (value.isEmpty) {
    return 'Please Enter $label';
  }
  return null;
}
