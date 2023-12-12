variable "name" {
  description = "Lambda layer name"
  type        = string
}

variable "python_version" {
  description = "Python version"
  type        = string
}

variable "requirements_path" {
  description = "requirements.txt file path"
  type        = string
  validation {
    condition     = fileexists(var.requirements_path)
    error_message = "The requirements file does not exist"
  }
}

variable "output_path" {
  description = "Output file path"
  type        = string
}
