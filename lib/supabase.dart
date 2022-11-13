import 'package:supabase/supabase.dart';
import 'package:planner/main.dart';

void main() {}

final supabase = SupabaseClient("https://uxsumctcqywllpjcbnxo.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV4c3VtY3RjcXl3bGxwamNibnhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjgzMzUwMDMsImV4cCI6MTk4MzkxMTAwM30.bmrIUG7DkpvV8POf-WVeseJr2P9xN3VxZ-CPEYZXCKQ");

void CreateUser(email, password) async {
  final AuthResponse res = await supabase.auth.signUp(
    email: email,
    password: password,
  );
  final user = res.user?.email;
  SaveUserInfo(user);
}

void LoginUser(email, password) async {
  final AuthResponse res = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  final user = res.user?.email;
  SaveUserInfo(user);
}