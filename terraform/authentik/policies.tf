resource "authentik_policy_password" "password-policy" {
  name          = "password-policy"
  length_min    = 8
  amount_digits = 1
  amount_lowercase = 1
  amount_symbols = 1
  amount_uppercase = 1
  
  check_zxcvbn = true
  zxcvbn_score_threshold = 2

  error_message = "Please choose a stronger password. It should include minimum 8 characters, with the minimum of one lowercase, uppercase letter, digit and symbol character."
}