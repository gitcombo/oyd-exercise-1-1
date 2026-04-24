resource "aws_s3_bucket" "exercise" {
 bucket = "oyd-exercise-bucket-2026"

 tags = {
   Environment = "dev"
   ManagedBy   = "terraform"
   Owner = "Estuardo Sabán | André Morales"   
 }
}