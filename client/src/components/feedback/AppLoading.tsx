function AppLoading() {
  return (
    <div className="bg-red-950">
      <svg className="w-16 h-16 animate-spin" viewBox="0 0 50 50" fill="none">
        <circle
          cx="25"
          cy="25"
          r="20"
          stroke="blue"
          strokeWidth="3"
          className="text-blue-500"
        />
        <circle
          cx="25"
          cy="25"
          r="20"
          stroke="red"
          strokeWidth="3"
          strokeLinecap="round"
          strokeDasharray="31.4 94.2"
          className="text-foreground"
        />
      </svg>
    </div>
  );
}

export default AppLoading;
