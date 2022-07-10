export class Account {
  public activated: boolean;
  public authorities: string[];
  public email: string;
  public firstName: string;
  public lastName: string;
  public langKey: string;
  public login: string;
  public imageUrl: string;

  constructor(
    activated: boolean,
    authorities: string[],
    email: string,
    firstName: string,
    lastName: string,
    langKey: string,
    login: string,
    imageUrl: string
  ) {
    activated = activated;
    authorities = authorities;
    email = email;
    firstName = firstName;
    lastName = lastName;
    langKey = langKey;
    login = login;
    imageUrl = imageUrl;
  }
}
