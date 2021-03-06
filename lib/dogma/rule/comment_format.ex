use Dogma.RuleBuilder

defrule Dogma.Rule.CommentFormat do
  @moduledoc """
  A rule that disallows comments with no space between the # and the comment
  text.

  This is considered valid:

      # Here is a function:
      #
      #   def inc(n), do: n + 1

  This is considered invalid:

      #Hello, world!
  """

  def test(_rule, script) do
    script.comments |> Enum.reduce([], &check_comment/2)
  end


  defp check_comment(comment, errors) do
    case comment.content do
      "" ->
        errors

      # Allow the 'shebang' line, common in *nix scripts.
      << "!"::utf8, _::binary >> ->
        if comment.line == 1,
          do: errors,
          else: [error( comment.line ) | errors]

      << " "::utf8, _::binary >> ->
        errors

      _ ->
        [error( comment.line ) | errors]
    end
  end

  defp error(pos) do
    %Error{
      rule:    __MODULE__,
      message: "Comments should start with a single space",
      line:    pos
    }
  end
end
