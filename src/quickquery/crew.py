from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task
from pydantic import BaseModel
from .tools import SQLExecutor

sql_executor = SQLExecutor()


class Validation(BaseModel):
    sql_query: str
    is_valid: str
    issues_found: list[str]


class Results(BaseModel):
    rows: list[dict]


@CrewBase
class Quickquery:
    """Quickquery crew"""

    agents_config = "config/agents.yaml"
    tasks_config = "config/tasks.yaml"

    @agent
    def query_generator(self) -> Agent:
        return Agent(config=self.agents_config["query_generator"], verbose=True)

    @agent
    def query_validator(self) -> Agent:
        return Agent(config=self.agents_config["query_validator"], verbose=True)

    @agent
    def query_runner_agent(self):
        return Agent(config=self.agents_config["query_runner_agent"])

    @task
    def generate_query_task(self) -> Task:
        return Task(
            config=self.tasks_config["generate_query_task"],
        )

    @task
    def validate_query_task(self) -> Task:
        return Task(
            config=self.tasks_config["validate_query_task"],
            output_pydantic=Validation,
        )

    @task
    def run_query_task(self) -> Task:
        return Task(
            config=self.tasks_config["run_query_task"],
            output_pydantic=Results,
            tools=[sql_executor],
        )

    @crew
    def crew(self) -> Crew:
        """Creates the QuickQuery crew"""

        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential,
            verbose=True,
        )
