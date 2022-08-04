import { screen, render } from '@testing-library/react';
import { Home } from '..';

it('should render with text Login', () => {
  render(<Home />);

  const homeTitle = screen.getByTestId('home-title');

  expect(homeTitle).toBeInTheDocument();
});
