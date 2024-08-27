# Deploying a flask app using ECS Fargate

The following ReadME explains the contents of the repository, as well as the approach and future improvements which could be made.

# Purpose of the repository
The path of the code journey within the repository is the following:
-   **Pull Request (PR) Trigger**: When a pull request is made to the main branch on GitHub, a GitHub Actions workflow is automatically triggered.
    
-   **Lint and Tests**: This workflow starts by running lint tests and pytests to ensure that the application code adheres to coding standards and is functioning correctly.
    
-   **Build and Push Docker Image**: If the lint and pytest checks pass, the workflow then triggers another job that connects to an AWS Elastic Container Registry (ECR). This job builds a new Docker image and pushes it to the ECR. This Docker image will later be used by the Amazon ECS service.
    
-   **Terraform Workflow**: Once the above is completed, another GitHub Actions workflow that runs Terraform. The Terraform plan is executed to test and validate the infrastructure configuration, ensuring it is correct and won't cause errors during provisioning.

-   **Merge Conditions**: Only after the lint tests and pytests have successfully passed will a user be able to merge the pull request into the main branch.
    
-   **Apply Terraform Changes**: Once the PR code is merged into the main branch of the GitHub repository, the Terraform apply step is run. This step provisions the infrastructure and launches the ECS cluster with the latest Docker image.
    
-   **Post-Merge Terraform Workflow**: After the merge is complete, the Terraform workflow will continue to manage and apply any necessary infrastructure updates to ensure everything is up-to-date and correctly configured.

The following explains the choices of tools/softwares used:

## Terraform

-   **Reusability**: Terraform configurations can be reused across different projects and environments, which reduces redundancy and simplifies management.
-   **Modules**: Terraform supports the use of modules, allowing to organise code into reusable components, making it easier to manage complex setups.
-   **Resource Creation**: Terraform helps in creating and linking resources effectively, ensuring that services are connected and configured properly.
-   **Ease of Use**: It simplifies the processes of spinning up and tearing down infrastructure, making it more efficient to manage environments and make changes.

## Github Actions

-   **Free to Use**: GitHub Actions is free for public repositories, this makes it cost-effective choice for automating workflows/pipelines.
    
-   **Integrated within GitHub**: Since GitHub Actions is built into GitHub, it allows for for easier automation of workflows directly within the same environment where the code is hosted. This reduces setup complexity and improves efficiency.
    
-   **Easy Storage of Secrets/Credentials**: GitHub Actions provides a secure and straightforward way to manage and store secrets and credentials. These secrets are encrypted and accessible only to the workflows that need them, ensuring sensitive information is handled safely.

## Flake8

- **Comprehensive Checks**: Flake8 combines multiple linting tools providing a broad range of code quality checks including syntax errors, style issues, and complexity metrics.

-   **Integration-Friendly**: Flake8 integrates well with various development tools and continuous integration systems, making it easy to incorporate linting into existing workflows and automate code quality checks.
    
-   **Improves Code Quality**: Using flake8 can help detecting potential issues early and maintain clean, readable, and maintainable code, reducing the likelihood of bugs and improving overall code quality.

## Pytest

-  **Ease of use**: pytest uses straightforward syntax that makes writing and understanding tests easy, which helps improve test readability and maintainability.

## Future Improvements

-   **Consider Using Terraform Cloud**:
    
    -   **State Management**: Easier storage and management of infrastructure state.
    -   **Collaboration**: Better suited for collaborative workflows, allowing teams to work together more effectively.
    -   **Multiple Environments**: Facilitates the creation of multiple environments by using separate workspaces for each.
    -   **Cost Considerations**: Potential downside is the cost associated with Terraform Cloud.
    
-   **Create More Modules for Resources**:
    
    -   **Ease of Provisioning**: Simplifies the provisioning of infrastructure by breaking it into manageable modules.
    -   **Reduced Dependencies**: Minimizes dependencies between resources, making the infrastructure more modular and maintainable.
    -   **Increased Reusability**: Enhances reusability of code across different projects and environments.
-   **Include Values as Variables**:
    
    -   **Increased Reusability**: Allows for the reuse of the same code with different values, improving flexibility and maintainability.
-   **Integrate a Logging System for the Cluster**:
    
    -   **Logging Solutions**: Use CloudWatch or a third-party system to monitor and log cluster activities, aiding in troubleshooting and performance monitoring.
-   **Add Branch Protection Rules**:
    
    -   **Access Control**: Restrict who can merge code to the main branch, such as requiring specific people or groups.
    -   **Approval Requirements**: Implement conditions like requiring a certain number of approvers (e.g., 2 approvers) before merging code.