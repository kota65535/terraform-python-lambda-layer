variable "name" {
  description = "Lambda layer name"
  type        = string
}

variable "python_version" {
  description = "Python version"
  type        = string
}

variable "requirements_file" {
  description = "requirements.txt file"
  type        = string
  validation {
    condition     = fileexists(var.requirements_file)
    error_message = "The requirements.txt file does not exist"
  }
}

variable "output_path" {
  description = "Output path"
  type        = string
}
