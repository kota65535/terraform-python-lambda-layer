package tests

import (
	"log"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestModule(t *testing.T) {
	// Arrange
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples",
	}

	// Act
	terraform.InitAndApply(t, terraformOptions)

	// Assert
	actual := make(map[string]interface{})
	terraform.OutputStruct(t, terraformOptions, "lambda_layer", &actual)
	assert.Equal(t, actual["layer_name"], "test")
	assert.Equal(t, actual["compatible_runtimes"], []interface{}{"python3.11"})

	// Replace name variable to trigger replacement
	err := replaceFile("../examples/main.tf", "\"test\"", "\"test2\"")
	if err != nil {
		log.Fatalf("cannot replace file, %v\n", err)
	}

	// Act
	terraform.InitAndApply(t, terraformOptions)

	// Assert
	terraform.OutputStruct(t, terraformOptions, "lambda_layer", &actual)
	assert.Equal(t, actual["layer_name"], "test2")
	assert.Equal(t, actual["compatible_runtimes"], []interface{}{"python3.11"})
}

func replaceFile(filename string, old string, new string) error {

	// Replace 'test' with 'test2'
	b, err := os.ReadFile(filename)
	if err != nil {
		log.Printf("cannot read file, %v\n", err)
		return err
	}
	input := string(b)

	// Replace "test" with "test2" in the content
	output := strings.ReplaceAll(input, "test", "test2")

	// Write the modified content back to the file
	err = os.WriteFile(filename, []byte(output), 0644)
	if err != nil {
		log.Printf("cannot write to file, %v\n", err)
		return err
	}
	return nil
}
