package pe.tuempresa.barberia_api;

import org.springframework.boot.SpringApplication;

public class TestBarberiaApiApplication {

	public static void main(String[] args) {
		SpringApplication.from(BarberiaApiApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
